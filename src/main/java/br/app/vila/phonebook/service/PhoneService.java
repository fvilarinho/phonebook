package br.app.vila.phonebook.service;

import br.app.vila.phonebook.model.Phone;
import br.app.vila.phonebook.repository.PhoneRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.Random;

@Service
public class PhoneService {
    private final PhoneRepository phoneRepository;

    public void test(){
        String var = null;

        if(var.equals("test"))
            System.out.println(new Random().nextInt());
    }

    @Autowired
    public PhoneService(PhoneRepository phoneRepository) {
        this.phoneRepository = phoneRepository;
    }

    public List<Phone> findAll() {
        return phoneRepository.findAll();
    }

    public Optional<Phone> findById(Long id) {
        if(id == null || id <= 0)
            throw new IllegalArgumentException("Please specify a phone id!");

        return phoneRepository.findById(id);
    }

    public List<Phone> findAllByName(String name) { return phoneRepository.findByNameContainingIgnoreCase(name); }

    public void save(Phone phone) throws IllegalArgumentException {
        if(phone == null || phone.getName() == null || phone.getName().isEmpty() || phone.getNumber() == null || phone.getNumber().isEmpty())
            throw new IllegalArgumentException("Please specify the phone details!");

        phoneRepository.save(phone);
    }

    public void deleteById(Long id) throws IllegalArgumentException {
        if(id == null || id <= 0)
            throw new IllegalArgumentException("Please specify a phone id!");

        phoneRepository.deleteById(id);
    }
}
